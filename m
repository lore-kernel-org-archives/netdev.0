From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6 patch] remove a superfluous #ifndef from net/ip.h
Date: Sun, 27 Jun 2004 20:39:15 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040627203915.65b56752.davem@redhat.com>
References: <20040627000222.GQ18303@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264647AbUF1Dlc@vger.kernel.org>
To: Adrian Bunk <bunk@fs.tum.de>
In-Reply-To: <20040627000222.GQ18303@fs.tum.de>
List-Id: netdev.vger.kernel.org

On Sun, 27 Jun 2004 02:02:23 +0200
Adrian Bunk <bunk@fs.tum.de> wrote:

> The patch below removes a superfluous #ifndef from net/ip.h (snmp.h is 
> guarded by the same #ifndef).
> 
> Signed-off-by: Adrian Bunk <bunk@fs.tum.de>

Looks good to me, applied.

Thanks.
