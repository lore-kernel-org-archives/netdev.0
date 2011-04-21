From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] tg3: Convert u32 flag,flg2,flg3 uses to bitmap
Date: Wed, 20 Apr 2011 23:52:23 -0700
Message-ID: <1303368743.24766.47.camel@Joe-Laptop>
References: <1303322263-18991-10-git-send-email-mcarlson@broadcom.com>
	 <02bf2aa5c08514641ecbe7c39ef976918fad036c.1303367730.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <02bf2aa5c08514641ecbe7c39ef976918fad036c.1303367730.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-04-20 at 23:39 -0700, Joe Perches wrote:
> Using a bitmap instead of separate u32 flags allows a consistent, simpler
> and more extensible mechanism to determine capabilities.

This is the second version of this patch.

I sent Matt privately a version a couple of weeks ago
to get his opinion before posting this one.

David, please don't apply unless/until Matt acks this.
It compiles but is untested here.
