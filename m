From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 9/11] net: dst_entry.refcount, use, lastuse to use
 alloc_percpu
Date: Tue, 13 Sep 2005 13:24:42 -0700 (PDT)
Message-ID: <20050913.132442.53540386.davem@davemloft.net>
References: <20050913155112.GB3570@localhost.localdomain>
	<20050913161708.GK3570@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, dipankar@in.ibm.com,
	bharata@in.ibm.com, shai@scalex86.org, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932316AbVIMUYw@vger.kernel.org>
To: kiran@scalex86.org
In-Reply-To: <20050913161708.GK3570@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There is no way in the world this enormous amount of NUMA
complexity is being added to the destination cache layer.

Sorry.
