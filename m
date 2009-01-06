From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: dccp test tree [RFC/RFT] [Patch 1/3] dccp: minor Kconfig cosmetics
Date: Mon, 5 Jan 2009 23:17:29 -0200
Message-ID: <39e6f6c70901051717p33da63b2ra8dade1da945624@mail.gmail.com>
References: <20090105144213.GB3773@gerrit.erg.abdn.ac.uk>
	 <4962AE90.3030706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: "Wei Yongjun" <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:45642 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbZAFBRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 20:17:33 -0500
In-Reply-To: <4962AE90.3030706@cn.fujitsu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 5, 2009 at 11:06 PM, Wei Yongjun <yjwei@cn.fujitsu.com> wrote:
> Gerrit Renker wrote:

>> +         value. Values in units of milliseconds can be set here.
>> +
>> +         A value of 0 disables this feature by enforcing the value
>> specified
>> +         in RFC 5448. The following values have been suggested as bounds
>> for
>>
>
> RFC 5448 should be RFC 5348.

Indeed.

- Arnaldo
