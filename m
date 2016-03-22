From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ath9k: fix checkpatch.pl identation and sapce errors.
Date: Tue, 22 Mar 2016 10:36:59 -0700
Message-ID: <1458668219.8482.23.camel@perches.com>
References: <1458629628-6264-1-git-send-email-Ashwini_Singh@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, ath9k-devel@venema.h4ckr.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rajeev_Kumar@mentor.com
To: Ashwini Singh <Ashwini_Singh@mentor.com>,
	ath9k-devel@qca.qualcomm.com, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458629628-6264-1-git-send-email-Ashwini_Singh@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-03-22 at 12:23 +0530, Ashwini Singh wrote:
> Signed-off-by: Ashwini Singh <Ashwini_Singh@mentor.com>

It might be better to break this into a few different patches.

o Remove trailing whitespace
o Fix vertical line / brace location
o Multi-line statement parenthesis alignment
o Space to tab conversions
o Whitespace addition / removal
