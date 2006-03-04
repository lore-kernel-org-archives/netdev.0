From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 7/8] [I/OAT] Add a sysctl for tuning the I/OAT offloaded I/O threshold
Date: Sat, 4 Mar 2006 14:22:21 +0300
Message-ID: <20060304112221.GA7790@mipter.zuzino.mipt.ru>
References: <20060303214036.11908.10499.stgit@gitlost.site> <20060303214234.11908.99495.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751470AbWCDLW3@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
Content-Disposition: inline
In-Reply-To: <20060303214234.11908.99495.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 03, 2006 at 01:42:34PM -0800, Chris Leech wrote:
> Any socket recv of less than this ammount will not be offloaded

There is no documentation update.
