export default {
  focusClass: 'focus',
  
  initFocus(element) {
    if (element) {
      element.focus()
    }
  },

  moveFocus(direction, currentElement, container) {
    const focusableElements = this.getFocusableElements(container)
    const currentIndex = focusableElements.indexOf(currentElement)
    
    if (currentIndex === -1) return

    let nextIndex = currentIndex
    
    switch(direction) {
      case 'up':
        nextIndex = Math.max(0, currentIndex - 1)
        break
      case 'down':
        nextIndex = Math.min(focusableElements.length - 1, currentIndex + 1)
        break
      case 'left':
        nextIndex = Math.max(0, currentIndex - 1)
        break
      case 'right':
        nextIndex = Math.min(focusableElements.length - 1, currentIndex + 1)
        break
    }
    
    if (nextIndex !== currentIndex && focusableElements[nextIndex]) {
      focusableElements[nextIndex].focus()
    }
  },

  getFocusableElements(container) {
    if (!container) return []
    return Array.from(container.querySelectorAll('[focusable="true"]'))
  },

  handleKeyEvent(event, handlers) {
    const keyMap = {
      'ArrowUp': 'up',
      'ArrowDown': 'down',
      'ArrowLeft': 'left',
      'ArrowRight': 'right',
      'Enter': 'enter',
      'Back': 'back'
    }
    
    const action = keyMap[event.key]
    if (action && handlers[action]) {
      handlers[action](event)
      event.preventDefault()
      return true
    }
    return false
  }
}
