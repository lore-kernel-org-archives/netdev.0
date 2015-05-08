From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [RFC PATCH v2 net-next] netlink: avoid namespace change while
 creating socket
Date: Fri, 8 May 2015 16:51:02 +0800
Message-ID: <554C78F6.3040609@windriver.com>
References: <1430892526-2446-1-git-send-email-ying.xue@windriver.com>	<CAHA+R7N4R4-=XKTpRzT1zvR61MZuwiQgk-+SgHiCvACq58fzSw@mail.gmail.com>	<554B28F4.8060301@windriver.com> <CAHA+R7MO9eKvbCd+jYf9U0Myr2dT0DXSZXiPq72AW+69n6+aag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35813 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbbEHIwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 04:52:31 -0400
In-Reply-To: <CAHA+R7MO9eKvbCd+jYf9U0Myr2dT0DXSZXiPq72AW+69n6+aag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/2015 02:21 AM, Cong Wang wrote:
> On Thu, May 7, 2015 at 1:57 AM, Ying Xue <ying.xue@windriver.com> wrote:
>>
>> Thanks to Cong! Your below idea is absolutely better than mine.
>>
>> I have created a whole series based on the idea. Please review them.
>> In addition, I am not sure whether I should use your "Suggested-by" or
>> "Signed-off-by" tag in the first patch. But I finally selected the
>> "Suggested-by". If you think the tag is inappropriate, please let me know. I
>> will replace it with "Signed-off-by" tag in next version.
>>
> 
> That is fairly easy to choose:
> 
> If you use any code from me, you need my Signed-off-by.
> If you only get suggestion without any code, then Suggested-by.
> 
> 

OK, thanks for the clarification.

Regards,
Ying
