From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] bcma: fix regression in pmu workaround reg masks
Date: Thu, 26 Jul 2012 14:07:14 -0700
Message-ID: <CA+55aFySBN=ajj=XKRzehw-_aVOOgLfoq9g5T9Wxht8nrQBSZA@mail.gmail.com>
References: <1343294151-5691-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linville@tuxdriver.com, davem@davemloft.net,
	brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	seth.forshee@canonical.com, pieterpg@broadcom.com,
	brudley@broadcom.com, Arend van Spriel <arend@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343294151-5691-1-git-send-email-hauke@hauke-m.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oops. For some reason I didn't see this email this morning, and grew
impatient and committed the patch without the sign-off and with a
different changelog.

My bad. Too much email.

Anyway, this is commit 1f03bf06e4e3 in my tree.

              Linus

On Thu, Jul 26, 2012 at 2:15 AM, Hauke Mehrtens <hauke@hauke-m.de> wrote:
> This fixes a regression introduced in:
> commit b9562545ef0b13c0440ccd8d6dd4111fb77cb17a
...
