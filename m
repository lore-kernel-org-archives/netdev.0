From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Bcm43xx-dev] [Fwd: State of the Union: Wireless]
Date: Fri, 06 Jan 2006 14:18:36 -0800 (PST)
Message-ID: <20060106.141836.41371212.davem@davemloft.net>
References: <1136549423.7429.88.camel@localhost>
	<43BE6697.3030009@trash.net>
	<Pine.LNX.4.62.0601061414570.334@qynat.qvtvafvgr.pbz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, marcel@holtmann.org, mbuesch@freenet.de,
	jgarzik@pobox.com, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932642AbWAFWTX@vger.kernel.org>
To: dlang@digitalinsight.com
In-Reply-To: <Pine.LNX.4.62.0601061414570.334@qynat.qvtvafvgr.pbz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Lang <dlang@digitalinsight.com>
Date: Fri, 6 Jan 2006 14:16:17 -0800 (PST)

> character devices are far easier to script. this really sounds like the 
> type of configuration stuff that sysfs was designed for. can we avoid yet 
> another configuration tool that's required?

netlink is being recommended exactly because it can result
in only needing one tool for everything
