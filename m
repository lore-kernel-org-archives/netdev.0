From: "David S. Miller" <davem@redhat.com>
Subject: Re: qfe problems on x86
Date: Tue, 23 Apr 2002 04:35:34 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20020423.043534.41652568.davem@redhat.com>
References: <20020423.043111.91362293.davem@redhat.com>
	<Pine.LNX.4.44.0204230759170.7811-100000@simon.ratbox.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: androsyn@ratbox.org
In-Reply-To: <Pine.LNX.4.44.0204230759170.7811-100000@simon.ratbox.org>
List-Id: netdev.vger.kernel.org

   From: Aaron Sethman <androsyn@ratbox.org>
   Date: Tue, 23 Apr 2002 08:00:59 -0400 (EDT)

   Initially they came up with 00:00:00:00:00:00

With the current 2.4.19-pre7 sunhme driver this should
never happen.  At worst it should use a random number
as the MAC address.

