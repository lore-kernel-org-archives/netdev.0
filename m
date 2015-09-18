From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2] geneve: remove vlan-related feature assignment
Date: Fri, 18 Sep 2015 13:32:22 -0700
Message-ID: <CAEP_g=9ijFTD9i3tzrb5QJc1izS8=JpWsTXehMRSUSotO=dT+A@mail.gmail.com>
References: <1442510338-10180-1-git-send-email-linville@tuxdriver.com> <1442607632-16580-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:34751 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbbIRUcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 16:32:43 -0400
Received: by lahg1 with SMTP id g1so37583548lah.1
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 13:32:41 -0700 (PDT)
In-Reply-To: <1442607632-16580-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 1:20 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> The code handling vlan tag insertion was dropped in commit 371bd1061d29
> ("geneve: Consolidate Geneve functionality in single module.").  Now we
> need to drop the related vlan feature bits in the netdev structure.
>
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>
