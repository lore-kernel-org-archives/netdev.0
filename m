From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2] bridge: Distinguish between externally learned
 vs offloaded FDBs
Date: Wed, 14 Jun 2017 09:52:50 -0700
Message-ID: <20170614095250.6cccc740@xeon-e3>
References: <20170605092043.3523-1-jiri@resnulli.us>
        <20170605100705.3909-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        arkadis@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33602 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750768AbdFNQw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 12:52:58 -0400
Received: by mail-pf0-f171.google.com with SMTP id 83so3050957pfr.0
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 09:52:57 -0700 (PDT)
In-Reply-To: <20170605100705.3909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  5 Jun 2017 12:07:05 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> Distinguish between externally learned vs offloaded FDBs. This is done
> in order to indicate that FDBs added by software was successfully
> offloaded.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied to net-next
