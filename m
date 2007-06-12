From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 11:23:09 -0400
Message-ID: <1181661789.4067.44.camel@localhost>
References: <D0122E209EBF8D4CAB38EC6A8AF244E502AB31CF@hasmsx412.ger.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Cohen, Guy" <guy.cohen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:4617 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754621AbXFLPXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 11:23:12 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1823091wxc
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 08:23:11 -0700 (PDT)
In-Reply-To: <D0122E209EBF8D4CAB38EC6A8AF244E502AB31CF@hasmsx412.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Guy,
I apologize for not responding immediately - i promise to in a few hours
when i get back (and read it over some good coffee) - seems like you
have some good stuff there; thanks for taking the time despite the
overload.

cheers,
jamal

On Tue, 2007-12-06 at 17:04 +0300, Cohen, Guy wrote:
> Hi Jamal,
> 
> Here is a simple scenario (nothing here is rare of extreme case):
> - Busy wireless environment
> - FTP TX on BE queue (low priority)
> - Skype TX on VO queue (high priority)
> 


