From: "Venkat Yekkirala" <vyekkirala@TrustedCS.com>
Subject: RE: [IPSEC] flow: Cache negative results
Date: Wed, 10 Jan 2007 09:26:06 -0600
Message-ID: <001201c734cb$a64ba810$cc0a010a@tcssec.com>
References: <Pine.LNX.4.64.0701100913050.8582@d.namei>
Reply-To: <vyekkirala@TrustedCS.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Paul Moore" <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:40144 "EHLO
	tcsfw4.tcs-sec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964920AbXAJQAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 11:00:17 -0500
To: "'James Morris'" <jmorris@namei.org>,
	"Herbert Xu" <herbert.xu@redhat.com>
In-Reply-To: <Pine.LNX.4.64.0701100913050.8582@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > So if the security folks actually care about this, they'd need to
> > flush the flow cache whenever a relevant change is made to the
> > security database.

I do not believe we are doing this. I will look into this ASAP.
