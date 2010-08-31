From: Dave Jones <davej@redhat.com>
Subject: Re: via-velocity dma-debug warnings again. (2.6.35.2)
Date: Mon, 30 Aug 2010 21:19:05 -0400
Message-ID: <20100831011905.GB11993@redhat.com>
References: <20100831011348.GA11993@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon.kagstrom@netinsight.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27039 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872Ab0HaBTU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 21:19:20 -0400
Content-Disposition: inline
In-Reply-To: <20100831011348.GA11993@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 30, 2010 at 09:13:48PM -0400, Dave Jones wrote:
 
 > WARNING: at lib/dma-debug.c:811 check_unmap+0x212/0x59b()
 > ... 
 > I haven't confirmed it yet, but I have a feeling this is due to c79992fddee28bbd31b35ac297e1068d32930179
 > Doing a build with that backed out now to test.

bad paste. I meant b6ca430599ea37843632b0eaa231dea5414dec25.
 
	Dave

