From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Thu, 01 Mar 2012 13:53:34 -0500
Message-ID: <1330628015.1026.148.camel@obelisk.thedillows.org>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E86@saturn3.aculab.com>
	 <1330606237.27405.5.camel@megeve>
	 <1330606775.2465.56.camel@edumazet-laptop>
	 <4F4F7FFB.6010608@collabora.co.uk>
	 <CABBYNZKN+7z4Sr9DBniokez6Jru02LxPgWdGNcVeYECse+AzEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABBYNZKN+7z4Sr9DBniokez6Jru02LxPgWdGNcVeYECse+AzEQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-03-01 at 18:02 +0200, Luiz Augusto von Dentz wrote:
> Contrary to someones believes I don't think AF_INET is that fast (e.g.
> http://scottmoonen.com/2008/04/05/a-performance-comparison-of-af_unix-with-loopback-on-linux/)

There has been a huge amount of work on the stack in the four years
since that was written, and even longer since 2.6.18 was considered
current.

Have anything more recent?
