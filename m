From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Bridge allows the userspace to configure the bridge
 parameters with values not defined in the IEEE 802.1D std
Date: Sat, 26 Mar 2011 08:55:36 -0700
Message-ID: <20110326085536.1ef03edb@nehalam>
References: <1301150997-4639-1-git-send-email-sasikanth.v19@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Sasikanth V <sasikanth.v19@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35164 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752217Ab1CZPzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2011 11:55:41 -0400
In-Reply-To: <1301150997-4639-1-git-send-email-sasikanth.v19@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Mar 2011 20:19:57 +0530
Sasikanth V <sasikanth.v19@gmail.com> wrote:

> 
> Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
> ---

I will clean this up. There are things like introducing
global function names (set_forward_delay, etc) that need
to be fixed.
