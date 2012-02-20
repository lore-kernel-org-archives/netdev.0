From: Colin Walters <walters@verbum.org>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Mon, 20 Feb 2012 14:13:44 -0500
Message-ID: <1329765252.22425.3.camel@lenny>
References: <1329753455-1106-1-git-send-email-javier@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Alban Crequy <alban.crequy@collabora.co.uk>,
	Bart Cerneels <bart.cerneels@collabora.co.uk>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Javier Martinez Canillas <javier@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329753455-1106-1-git-send-email-javier@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-02-20 at 16:57 +0100, Javier Martinez Canillas wrote:
> This patch-set add multicast support to Unix domain socket familiy for datagram
> and seqpacket sockets. This work was made by Alban Crequy as a result of a
> research we have been doing to improve the performance of the D-bus IPC system.

Do you have links to any modifications to userspace dbus to take
advantage of this?
