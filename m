From: "Ayaz Abdulla" <AAbdulla@nvidia.com>
Subject: RE: [PATCH 2/2] forcedeth: scatter gather and segmentation offload support
Date: Tue, 25 Oct 2005 23:17:13 -0700
Message-ID: <DBFABB80F7FD3143A911F9E6CFD477B00BA5D799@hqemmail02.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>,
        "Manfred Spraul" <manfred@colorfullife.com>,
        "Netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks.

I will resend version 45 (bug fix) and 46 (irq modes) since they will
need new modifications based on the changes made in this patch and the
comments you suggested.


-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com] 
Sent: Tuesday, October 25, 2005 9:53 PM
To: Ayaz Abdulla
Cc: Stephen Hemminger; Manfred Spraul; Netdev
Subject: Re: [PATCH 2/2] forcedeth: scatter gather and segmentation
offload support


Ayaz Abdulla wrote:
> Yes, forgot that indent.
> 
> Here it is again with that fix.

I applied this version of the patch to the 'upstream' patch.

In the future, as Stephen noted, it would really be preferred that you 
split up the patch into logical changes.  patch 1/2 netdev_priv(), patch

2/2 SG support, for example.

Also, always include the Signed-off-by line, even on patch resends.  See
	http://linux.yyz.us/patch-format.html
for more info.

	Jeff
