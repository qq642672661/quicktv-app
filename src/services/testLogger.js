import storage from '@system.storage'

class TestLogger {
  constructor() {
    this.testMode = false
    this.logs = []
    this.stats = {
      videoPlays: 0,
      livePlays: 0,
      errors: 0,
      apiCalls: 0,
      startTime: null
    }
    this.loadTestMode()
  }

  loadTestMode() {
    storage.get({
      key: 'test_mode',
      success: (data) => {
        this.testMode = data === 'true'
        if (this.testMode) {
          this.stats.startTime = Date.now()
          this.log('info', 'Test mode enabled')
        }
      }
    })
  }

  enableTestMode() {
    this.testMode = true
    this.stats.startTime = Date.now()
    storage.set({
      key: 'test_mode',
      value: 'true'
    })
    this.log('info', 'Test mode enabled')
  }

  disableTestMode() {
    this.testMode = false
    storage.set({
      key: 'test_mode',
      value: 'false'
    })
    this.log('info', 'Test mode disabled')
  }

  setTestMode(enabled) {
    if (enabled) {
      this.enableTestMode()
    } else {
      this.disableTestMode()
    }
  }

  isTestMode() {
    return this.testMode
  }

  log(level, message, data = null) {
    if (!this.testMode) return

    const logEntry = {
      timestamp: Date.now(),
      level,
      message,
      data
    }

    this.logs.push(logEntry)
    console.log(`[${level.toUpperCase()}] ${message}`, data || '')

    if (this.logs.length > 1000) {
      this.logs = this.logs.slice(-500)
    }

    this.saveLogs()
  }

  logVideoPlay(videoId, videoName) {
    this.stats.videoPlays++
    this.log('info', 'Video play', { videoId, videoName })
    this.saveStats()
  }

  logLivePlay(channelId, channelName) {
    this.stats.livePlays++
    this.log('info', 'Live play', { channelId, channelName })
    this.saveStats()
  }

  logError(error, context = '') {
    this.stats.errors++
    this.log('error', `Error in ${context}`, {
      message: error.message || error,
      stack: error.stack || ''
    })
    this.saveStats()
  }

  logApiCall(endpoint, method, duration, success) {
    this.stats.apiCalls++
    this.log('info', 'API call', {
      endpoint,
      method,
      duration,
      success
    })
    this.saveStats()
  }

  saveLogs() {
    storage.set({
      key: 'test_logs',
      value: JSON.stringify(this.logs.slice(-100))
    })
  }

  saveStats() {
    storage.set({
      key: 'test_stats',
      value: JSON.stringify(this.stats)
    })
  }

  getLogs() {
    return this.logs
  }

  getStats() {
    return {
      ...this.stats,
      duration: this.stats.startTime ? Date.now() - this.stats.startTime : 0
    }
  }

  clearLogs() {
    this.logs = []
    this.stats = {
      videoPlays: 0,
      livePlays: 0,
      errors: 0,
      apiCalls: 0,
      startTime: Date.now()
    }
    this.saveLogs()
    this.saveStats()
    this.log('info', 'Logs and stats cleared')
  }

  exportData() {
    return {
      testMode: this.testMode,
      logs: this.logs,
      stats: this.getStats(),
      exportTime: Date.now()
    }
  }

  getRecentLogs(count = 50) {
    return this.logs.slice(-count)
  }

  getLogsByLevel(level) {
    return this.logs.filter(log => log.level === level)
  }

  getLogsByTimeRange(startTime, endTime) {
    return this.logs.filter(log => 
      log.timestamp >= startTime && log.timestamp <= endTime
    )
  }

  getSummary() {
    const stats = this.getStats()
    const errorLogs = this.getLogsByLevel('error')
    const duration = stats.duration
    const hours = Math.floor(duration / 3600000)
    const minutes = Math.floor((duration % 3600000) / 60000)
    const seconds = Math.floor((duration % 60000) / 1000)

    return {
      testMode: this.testMode,
      duration: `${hours}h ${minutes}m ${seconds}s`,
      durationMs: duration,
      totalLogs: this.logs.length,
      stats: {
        videoPlays: stats.videoPlays,
        livePlays: stats.livePlays,
        errors: stats.errors,
        apiCalls: stats.apiCalls
      },
      recentErrors: errorLogs.slice(-5).map(log => ({
        time: new Date(log.timestamp).toLocaleString(),
        message: log.message,
        data: log.data
      })),
      startTime: stats.startTime ? new Date(stats.startTime).toLocaleString() : null
    }
  }

  async loadStoredData() {
    return new Promise((resolve) => {
      storage.get({
        key: 'test_logs',
        success: (data) => {
          try {
            this.logs = JSON.parse(data) || []
          } catch (e) {
            this.logs = []
          }
          
          storage.get({
            key: 'test_stats',
            success: (statsData) => {
              try {
                this.stats = JSON.parse(statsData) || this.stats
              } catch (e) {
                this.stats = {
                  videoPlays: 0,
                  livePlays: 0,
                  errors: 0,
                  apiCalls: 0,
                  startTime: null
                }
              }
              resolve()
            },
            fail: () => {
              resolve()
            }
          })
        },
        fail: () => {
          resolve()
        }
      })
    })
  }
}

export default new TestLogger()
