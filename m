From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] AFS: Make the match_*() functions take const
 options
Date: Thu, 03 May 2007 03:10:52 -0700 (PDT)
Message-ID: <20070503.031052.106746215.davem@davemloft.net>
References: <20070501174747.19112.1985.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	geert@linux-m68k.org
To: dhowells@redhat.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070501174747.19112.1985.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 01 May 2007 18:47:47 +0100

> Make the match_*() functions take a const pointer to the options table and
> make strings pointers in the options table const too.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

I'll take this, applied, thanks David.
