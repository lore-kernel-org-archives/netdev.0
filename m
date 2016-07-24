From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [ethtool PATCH v2 4/4] ethtool: Enhancing link mode bits to
 support 25G/50G/100G
Date: Sun, 24 Jul 2016 05:57:43 +0000
Message-ID: <CO2PR11MB00889D2C55C1E4C86D831C59970C0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1466970307-2411-5-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bkenward@solarflare.com" <bkenward@solarflare.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>,
	"galp@mellanox.com" <galp@mellanox.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"dustin@cumulusnetworks.com" <dustin@cumulusnetworks.com>
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>,
	"bwh@kernel.org" <bwh@kernel.org>,
	David Miller <davem@davemloft.net>,
	"decot@googlers.com" <decot@googlers.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0138.outbound.protection.outlook.com ([104.47.42.138]:8055
	"EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751539AbcGXGcJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2016 02:32:09 -0400
In-Reply-To: <1466970307-2411-5-git-send-email-vidya@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Enhancing link mode bits to support 25G/50G/100G for supported and
> advertised speed mode bits
> 
> Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
> ---
>  ethtool.c | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)

Hi Vidya,

Are you re-trying your series one anytime soon?

If not, can we simply push this [and ethtool-copy.h], as those are needed
for querying/setting the recently added new speeds.
