From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: fix dma operation mode config for older
 versions
Date: Tue, 21 Mar 2017 20:53:46 +0300
Message-ID: <a9aa6a41-d5d1-80fd-6d8c-74db98ee7dec@cogentembedded.com>
References: <3b8aeab69d2987db68c74f48a3ac13c7241e1542.1490117473.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        clabbe.montjoie@gmail.com, thierry.reding@gmail.com,
        netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:33247 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932875AbdCURxu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 13:53:50 -0400
Received: by mail-lf0-f42.google.com with SMTP id a6so70038566lfa.0
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 10:53:49 -0700 (PDT)
In-Reply-To: <3b8aeab69d2987db68c74f48a3ac13c7241e1542.1490117473.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2017 08:36 PM, Joao Pinto wrote:

> This patch fixes a bug introduced in commit:
> 6deee22 (net: stmmac: prepare dma op mode config for multiple queues)

    Need 12 hex digits and the commit summary enclosed into ("").

> The dma operation mode configuration routine was wrongly moved to a
> function (stmmac_mtl_configuration) that is only executed if the
> core version is >= 4.00.
>
> Reported-by: Corentin Labbe <clabbe.montjoie@gmail.com>
>
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
[...]

MBR, Sergei
