From: Mike Auty <mike.auty@gmail.com>
Subject: Re: [Bugme-new] [Bug 41152] New: kernel 3.0 and above fails to handle
 vlan id 0 (802.1p) packets properly without hardware acceleration
Date: Thu, 18 Aug 2011 20:39:18 +0100
Message-ID: <4E4D6A66.3080908@gmail.com>
References: <bug-41152-10286@https.bugzilla.kernel.org/> <20110816150918.5b2d7067.akpm@linux-foundation.org> <20110817053737.GA1936@minipsycho> <4E4B615F.8060403@gmail.com> <20110817105950.GA4259@minipsycho.brq.redhat.com> <4E4C4549.6020802@gmail.com> <20110818163702.GA1911@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:44918 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751295Ab1HRTjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 15:39:21 -0400
In-Reply-To: <20110818163702.GA1911@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/08/11 17:37, Jiri Pirko wrote:
> 
> Patch posted:
> http://patchwork.ozlabs.org/patch/110535/
> 
> sorry I forgot to cc you Mike. Thanks a lot for report!

No problem,

Thanks very much for the speedy fix!  I've applied the patch and can
confirm it solves my problem.  I look forward to seeing it hit the
mainline...  5:)

Mike  5:)
