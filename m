From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 01/15] net: proc entry showing inodes on sockfs and
 their types
Date: Sat, 11 Aug 2012 21:05:40 -0700 (PDT)
Message-ID: <20120811.210540.1158066885515664193.davem@davemloft.net>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yamato@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I also want to mention that I absolutely do not consider better lsof
support important at all.

So if you want to add this, it had to be exactly zero overhead and it
must not break anything that exists already.  Your patch set violates
this on both counts.
