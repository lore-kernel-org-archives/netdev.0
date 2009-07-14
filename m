From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] NET: sungem, use spin_trylock_irqsave
Date: Mon, 13 Jul 2009 19:12:07 -0700 (PDT)
Message-ID: <20090713.191207.212695734.davem@davemloft.net>
References: <1247520220-31960-1-git-send-email-jirislaby@gmail.com>
	<1247520220-31960-2-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753197AbZGNCMG@vger.kernel.org>
In-Reply-To: <1247520220-31960-2-git-send-email-jirislaby@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please DO NOT combine cleanups with real bug fixes into
a patch series.

Bug fixes go to one tree, the rest go to another tree, and that is
especially the case this late in the RC series.

A series of patches are a group of changes that are supposed to be
related and are expected to be applied all to the same tree.  That is
not true of the patches you have posted here.
