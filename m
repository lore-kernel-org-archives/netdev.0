From: Phil Reid <preid@electromag.com.au>
Subject: Re: [PATCH v2 5/5] stmmac: socfpga: Provide dt node to config ptp clk
 source.
Date: Mon, 7 Dec 2015 21:31:27 +0800
Message-ID: <56658A2F.9030502@electromag.com.au>
References: <1449452324-53858-1-git-send-email-preid@electromag.com.au>
 <1449452324-53858-7-git-send-email-preid@electromag.com.au>
 <566574BD.9010204@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, davem@davemloft.net,
	devicetree@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchovy1.45ru.net.au ([203.30.46.145]:49452 "EHLO
	anchovy.45ru.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755516AbbLGNbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 08:31:39 -0500
In-Reply-To: <566574BD.9010204@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/12/2015 7:59 PM, Sergei Shtylyov wrote:
> On 12/07/2015 04:38 AM, Phil Reid wrote:
>> +    if(dwmac->f2h_ptp_ref_clk)
>
>     Please run your patches thru scripts/checkpatch.pl (space needed after *if*).
>
> [...]
>
> MBR, Sergei
>

Will do.

-- 
Regards
Phil Reid
