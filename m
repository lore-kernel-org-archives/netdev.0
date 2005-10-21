From: "Ayaz Abdulla" <AAbdulla@nvidia.com>
Subject: RE: [patch] forcedeth: add support for interrupt mitigation
Date: Fri, 21 Oct 2005 14:10:51 -0700
Message-ID: <DBFABB80F7FD3143A911F9E6CFD477B00BA5D745@hqemmail02.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Manfred Spraul" <manfred@colorfullife.com>, "Netdev" <netdev@oss.sgi.com>,
        "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>,
        "Francois Romieu" <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yes, thats right. I just gave Manfred the hardware interrupt mitigation
patch (v46). Next, I will implement NAPI.

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com] 
Sent: Friday, October 21, 2005 2:07 PM
To: Francois Romieu
Cc: Manfred Spraul; Netdev; Ayaz Abdulla; John W. Linville
Subject: Re: [patch] forcedeth: add support for interrupt mitigation


FWIW the ideal is to implement both NAPI -and- hardware interrupt 
mitigation.

	Jeff
