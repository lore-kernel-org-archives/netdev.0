From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 4/5] bridge: vlan lwt and dst_metadata netlink
 support
Date: Mon, 23 Jan 2017 07:39:20 -0800
Message-ID: <588623A8.6010906@cumulusnetworks.com>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com> <1484977616-1541-5-git-send-email-roopa@cumulusnetworks.com> <9B0331B6EBBD0E4684FBFAEDA55776F93D495F16@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
        "tgraf@suug.ch" <tgraf@suug.ch>,
        "hannes@stressinduktion.org" <hannes@stressinduktion.org>,
        "jbenc@redhat.com" <jbenc@redhat.com>,
        "pshelar@ovn.org" <pshelar@ovn.org>,
        "dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>,
        "hadi@mojatatu.com" <hadi@mojatatu.com>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34705 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751283AbdAWPjY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 10:39:24 -0500
Received: by mail-pg0-f45.google.com with SMTP id 14so45872025pgg.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 07:39:24 -0800 (PST)
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F93D495F16@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/22/17, 4:22 PM, Rosen, Rami wrote:
> Hi, Roopa,
>
> Two minor comments:
>
> The parameter br is not used in the br_add_vlan_tunnel_info() method, it should be removed:

Thanks Rami. will take care of this in the next version.
