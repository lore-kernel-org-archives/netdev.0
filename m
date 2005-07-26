From: Miika Komu <miika@iki.fi>
Subject: Re: [PATCH 2.6.12.2] XFRM: BEET IPsec mode for Linux
Date: Tue, 26 Jul 2005 16:02:59 +0300 (EEST)
Message-ID: <Pine.GSO.4.58.0507261552540.26326@kekkonen.cs.hut.fi>
References: <1122295307.14873.37.camel@odysse>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1122295307.14873.37.camel@odysse>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Ericsson has already developed a BEET patch for *BSD. Our patch
> provides the similar functionality, but using the XFRM architecture.
> The patch is included at the end of this email and also at the following
> URL:
> http://hipl.hiit.fi/beet/beet-patch-v1.0-2.6.12.2

We added more files to the same directory that are helpful for testing the
patch. There is a patch for setkey which enables you to configure security
associations manually. Also, there is a simple script that can be used for
quick testing of ping over BEET ESP security associations.

http://hipl.hiit.fi/beet/ipsec-tools-0.5.1-patch-beet
http://hipl.hiit.fi/beet/run-beet.sh

Looking forward for feedback,
-- 
Miika Komu              miika@iki.fi          http://www.iki.fi/miika/
