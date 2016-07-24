From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: Re: [ethtool PATCH v2 4/4] ethtool: Enhancing link mode bits to
 support 25G/50G/100G
Date: Sun, 24 Jul 2016 02:12:34 -0700
Message-ID: <CAKWE-Xq0RLTyT64xYZ6zxX4J1Q_4hEV7P-fW-BhpvuTyzJV5NQ@mail.gmail.com>
References: <1466970307-2411-5-git-send-email-vidya@cumulusnetworks.com> <CO2PR11MB00889D2C55C1E4C86D831C59970C0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>,
	"bwh@kernel.org" <bwh@kernel.org>,
	David Miller <davem@davemloft.net>,
	"decot@googlers.com" <decot@googlers.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"bkenward@solarflare.com" <bkenward@solarflare.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>,
	"galp@mellanox.com" <galp@mellanox.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"dustin@cumulusnetworks.com" <dustin@cumulusnetworks.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:33052 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbcGXJMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2016 05:12:35 -0400
Received: by mail-yw0-f181.google.com with SMTP id r9so138205102ywg.0
        for <netdev@vger.kernel.org>; Sun, 24 Jul 2016 02:12:35 -0700 (PDT)
In-Reply-To: <CO2PR11MB00889D2C55C1E4C86D831C59970C0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yuval,
    I will try to resubmit the patches this week with updated comments

Thanks
Vidya Sagar

On Sat, Jul 23, 2016 at 10:57 PM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>> Enhancing link mode bits to support 25G/50G/100G for supported and
>> advertised speed mode bits
>>
>> Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>> ---
>>  ethtool.c | 27 +++++++++++++++++++++++++++
>>  1 file changed, 27 insertions(+)
>
> Hi Vidya,
>
> Are you re-trying your series one anytime soon?
>
> If not, can we simply push this [and ethtool-copy.h], as those are needed
> for querying/setting the recently added new speeds.
>
