From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] net: typhoon: Remove redundant casts
Date: Tue, 21 Oct 2014 14:29:03 -0700
Message-ID: <1413926943.8038.0.camel@dillow0.mtv.corp.google.com>
References: <1413903103-3047-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413903103-3047-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-10-21 at 16:51 +0200, Rasmus Villemoes wrote:
> Both image_data and typhoon_fw->data are const u8*, so the cast to u8*
> is unnecessary and confusing.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Acked-by: David Dillow <dave@thedillows.org>
