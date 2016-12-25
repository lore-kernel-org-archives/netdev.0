From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] drivers: net: ethernet: 3com: fix return value
Date: Sat, 24 Dec 2016 19:56:54 -0500 (EST)
Message-ID: <20161224.195654.1632303818126752071.davem@davemloft.net>
References: <4200be74-f7e7-db6b-a258-8fd178fef369@cogentembedded.com>
        <1482625822-19658-1-git-send-email-thomas.preisner+linux@fau.de>
        <1482625822-19658-2-git-send-email-thomas.preisner+linux@fau.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, dave@thedillows.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kernel@i4.cs.fau.de, milan.stephan+linux@fau.de
To: thomas.preisner+linux@fau.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482625822-19658-2-git-send-email-thomas.preisner+linux@fau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It is never, ever, appropriate to use the same exact Subject: line
text for two different changes.

Someone looking at "git shortlog" has no way to know what is different
between the two changes.

You must put care and time into constructing Subject: lines because
this text is critical for data mining and analysis done by both humans
and machines.
