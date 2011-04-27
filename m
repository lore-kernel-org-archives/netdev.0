From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 1/4] ethtool: cosmetics: enforce const-ness in
 ethtool_cmd_speed
Date: Wed, 27 Apr 2011 19:41:03 +0100
Message-ID: <1303929663.2875.97.camel@bwh-desktop>
References: <1303001651-4074-1-git-send-email-decot@google.com>
	 <1303929290-21037-2-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, mirq-linux@rere.qmqm.pl,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Decotigny <decot@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303929290-21037-2-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-04-27 at 11:34 -0700, David Decotigny wrote:
> The 'ep' argument of ethtool_cmd_speed is not altered: advertise it in
> protoype. +Indentation fix. Also add comments to advise using the
> ethtool_cmd_speed API to get/set the link speed.
> 
> Signed-off-by: David Decotigny <decot@google.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
