From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ethernet/sfc: report supported link speeds on SFP
 connections
Date: Fri, 03 Jun 2016 19:50:25 -0400 (EDT)
Message-ID: <20160603.195025.58262557957007222.davem@davemloft.net>
References: <1464917604-11596-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net-drivers@solarflare.com,
	ecree@solarflare.com, bkenward@solarflare.com,
	netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464917604-11596-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Thu,  2 Jun 2016 21:33:24 -0400

> My solarflare cards connected to a 10GbE switch with an SFP+ module/cable
> don't currently report any supported link speeds:
 ...
> CC: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
> CC: Edward Cree <ecree@solarflare.com>
> CC: Bert Kenward <bkenward@solarflare.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Solarflare maintainers, please review.
