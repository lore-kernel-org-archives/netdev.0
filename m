From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH cumulus-4.1.y 1/5] vxlan: flush fdb entries on oper down
Date: Fri, 20 Jan 2017 23:41:44 -0800
Message-ID: <588310B8.3040503@cumulusnetworks.com>
References: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35663 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751080AbdAUHlq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 02:41:46 -0500
Received: by mail-pg0-f50.google.com with SMTP id 194so29805746pgd.2
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 23:41:46 -0800 (PST)
In-Reply-To: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/20/17, 11:40 PM, Roopa Prabhu wrote:
> From: Balakrishnan Raman <ramanb@cumulusnetworks.com>
>
> Flush fdb entries of a vxlan device when its state
> changes to oper down. vxlan_stop handles flush on
> admin down.
>
> Signed-off-by: Balakrishnan Raman <ramanb@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  

pls ignore this series. Accidently hit send in the wrong folder :(
