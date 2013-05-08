From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] if_cablemodem.h: Add parenthesis around ioctl macros
Date: Wed, 08 May 2013 13:16:22 -0700 (PDT)
Message-ID: <20130508.131622.793679021804441217.davem@davemloft.net>
References: <20130508194547.GE16269@hansolo.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pwouters@redhat.com
To: jwboyer@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130508194547.GE16269@hansolo.jdub.homelinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Boyer <jwboyer@redhat.com>
Date: Wed, 8 May 2013 15:45:47 -0400

> Protect the SIOCGCM* ioctl macros with parenthesis.
> 
> Reported-by: Paul Wouters <pwouters@redhat.com>
> Signed-off-by: Josh Boyer <jwboyer@redhat.com>

Applied and queued up for -stable.
