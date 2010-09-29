From: Jesse Gross <jesse@nicira.com>
Subject: Re: null dereference in ipip6_get_stats in linux-next
Date: Wed, 29 Sep 2010 09:39:30 -0700
Message-ID: <AANLkTin2E2ACB5yiAUA7MbYqzYyMKAi+syFOCzXWqVrY@mail.gmail.com>
References: <20100929162625.GB17087@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100929162625.GB17087@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2010 at 9:26 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> Last night's linux-next fails to boot for me; apologies if this is already
> known.

Eric sent out a patch for this:
http://patchwork.ozlabs.org/patch/65961/
