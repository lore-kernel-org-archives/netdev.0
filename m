From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [ANN] Acrypto asynchronous crypto layer 2.6.19 release.
Date: Mon, 18 Dec 2006 12:57:40 +0300
Message-ID: <20061218095740.GA5219@2ka.mipt.ru>
References: <20061216191521.GA26549@2ka.mipt.ru> <4586458E.6000503@dungeon.inka.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
To: Andreas Jellinghaus <aj@dungeon.inka.de>
Content-Disposition: inline
In-Reply-To: <4586458E.6000503@dungeon.inka.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 18, 2006 at 08:38:54AM +0100, Andreas Jellinghaus (aj@dungeon.inka.de) wrote:
> Does acrypto still have the same size restrictions
> I ran into with the last release?

Actually I do not recall what is 'size retrictions' - if you talk about
possibility to use software crypto provider, which supports one cipher
in a time, then yes, but it is intended to be used with hardware though.
Otherwise I do not recall any problems pointed to me.

> Thanks, Andreas

-- 
	Evgeniy Polyakov
