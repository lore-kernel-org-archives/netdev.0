From: deepaksi <deepak.sikri@st.com>
Subject: Re: [PATCH 4/6] stmmac: Update stmmac descriptor checks for stmmac
 core prior to Rev-3.5.
Date: Wed, 7 Mar 2012 13:56:26 +0530
Message-ID: <4F571BB2.1030004@st.com>
References: <1330692928-30330-3-git-send-email-deepak.sikri@st.com> <1330692928-30330-4-git-send-email-deepak.sikri@st.com> <1330692928-30330-5-git-send-email-deepak.sikri@st.com> <20120304.205155.650947216183181836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peppe CAVALLARO <peppe.cavallaro@st.com>,
	spear-devel <spear-devel@list.st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:54525 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754123Ab2CGI1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 03:27:06 -0500
In-Reply-To: <20120304.205155.650947216183181836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi David,

On 3/5/2012 7:21 AM, David Miller wrote:
> From: Deepak Sikri<deepak.sikri@st.com>
> Date: Fri, 2 Mar 2012 18:25:26 +0530
>
>> +static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err,
>> +		u32 mac_id)
> Poorly formatted, this should be:
Sorry for that.. Will rectify that

> static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err,
> 			      u32 mac_id)
>
>
>> +			/*
>> +			 * The type-1 checksume offload engines append
>> +			 * the checksum at the end of frame, and the
> 	/* Format comments
> 	 * like this.
> 	 */
>
> 	/*
> 	 * Not
> 	 * like this.
> 	 */
>

Sure..  will do that


Regards
Deepak
