From: "David S. Miller" <davem@redhat.com>
Subject: Re: qfe problems on x86
Date: Tue, 23 Apr 2002 04:31:11 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20020423.043111.91362293.davem@redhat.com>
References: <20020423.035453.96160070.davem@redhat.com>
	<Pine.LNX.4.44.0204230749260.7811-100000@simon.ratbox.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: androsyn@ratbox.org
In-Reply-To: <Pine.LNX.4.44.0204230749260.7811-100000@simon.ratbox.org>
List-Id: netdev.vger.kernel.org

   From: Aaron Sethman <androsyn@ratbox.org>
   Date: Tue, 23 Apr 2002 07:57:00 -0400 (EDT)

   Okay, tried it this time.  It worked for a short period of time, as I
   could ping the default gateway.  When I tried to ping it from another
   host, that is when it decided it would go dead.  This time, it did not go
   crazy and lock the system up at least.  I tried at both full and half
   duplex, with the same experience.
   
What MAC address do the qfe interfaces come up with?
