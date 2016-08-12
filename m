From: Philp Prindeville <philipp@redfish-solutions.com>
Subject: Re: [PATCH v1 1/1] pptp: Refactor the struct and macros of PPTP codes
Date: Fri, 12 Aug 2016 12:51:54 -0600
Message-ID: <e536bbe8-3130-0ee6-eea7-40711a26db13@redfish-solutions.com>
References: <1471019448-3336-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gfree.wind@gmail.com
To: fgao@48lvckh6395k16k5.yundunddos.com, davem@davemloft.net,
	stephen@networkplumber.org, pshelar@nicira.com,
	tom@herbertland.com, xeb@mail.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:53054 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752583AbcHLSyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 14:54:10 -0400
In-Reply-To: <1471019448-3336-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 08/12/2016 10:30 AM, fgao@48lvckh6395k16k5.yundunddos.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> 1. Use struct gre_base_hdr directly in pptp_gre_header instead of
> duplicated members;
> 2. Use existing macros like GRE_KEY, GRE_SEQ, and so on instead of
> duplicated macros defined by PPTP;
> 3. Add new macros like GRE_IS_ACK/SEQ and so on instead of
> PPTP_GRE_IS_A/S and so on;
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>

Reviewed-by: Philip Prindeville <philipp@redfish-solutions.com>
