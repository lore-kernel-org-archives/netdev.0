From: "David S. Miller" <davem@redhat.com>
Subject: Re: qfe problems on x86
Date: Tue, 23 Apr 2002 03:54:53 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20020423.035453.96160070.davem@redhat.com>
References: <20020423.034450.102874103.davem@redhat.com>
	<Pine.LNX.4.44.0204230714530.7811-100000@simon.ratbox.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: androsyn@ratbox.org
In-Reply-To: <Pine.LNX.4.44.0204230714530.7811-100000@simon.ratbox.org>
List-Id: netdev.vger.kernel.org

   From: Aaron Sethman <androsyn@ratbox.org>
   Date: Tue, 23 Apr 2002 07:19:25 -0400 (EDT)

   I'm *certain* this is a switch, albeit a cheap, unmanaged one, I've got
   other devices hanging off of it that are just happy at 100MB/full duplex
   right now. Also I am not forcing it to full duplex, this is what it is
   trying to do on its own.
   
It means it cannot negotiate this with the switch for some reason.

Does trying to force full duplex using 'ethtool' have any
effect?
