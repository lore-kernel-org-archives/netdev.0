From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] - Wrong use of RTM_BASE in XFRM message types.
Date: Sun, 25 May 2003 19:48:20 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030525.194820.26298304.davem@redhat.com>
References: <3ECE64F2.5000300@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: krkumar@us.ibm.com
In-Reply-To: <3ECE64F2.5000300@us.ibm.com>
List-Id: netdev.vger.kernel.org

   From: Krishna Kumar <krkumar@us.ibm.com>
   Date: Fri, 23 May 2003 11:14:10 -0700

   I am using 2.5.68 and found XFRM_MSG_BASE being defined, but
   RTM_BASE used for all XFRM messages, changed it. Current mailer
   (hopefully) shouldn't screw up the tabs.

Applied, thank you.
