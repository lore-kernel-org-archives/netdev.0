From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] tc: remove unused redirect ttl
Date: Fri, 01 May 2015 20:15:49 -0700
Message-ID: <55444165.3050401@plumgrid.com>
References: <55435313.9030706@cogentembedded.com>	<5543B7D6.9050508@plumgrid.com>	<CAHA+R7NOr4aQMXfC7yMuzy3dKRTJB9AYg5HMD2zVXLHM5iZYyw@mail.gmail.com> <20150501.194821.135988326109135305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, jhs@mojatatu.com,
	daniel@iogearbox.net, fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36068 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbbEBDPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 23:15:51 -0400
Received: by pabsx10 with SMTP id sx10so107464635pab.3
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 20:15:50 -0700 (PDT)
In-Reply-To: <20150501.194821.135988326109135305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/1/15 4:48 PM, David Miller wrote:
> From: Cong Wang <cwang@twopensource.com>
> Date: Fri, 1 May 2015 13:33:28 -0700
>
>> Quote from Documentation/SubmittingPatches:
>>
>> "
>> The "from" line must be the very first line in the message body,
>> and has the form:
>>
>>          From: Original Author <author@example.com>
>>
>> The "from" line specifies who will be credited as the author of the
>> patch in the permanent changelog.  If the "from" line is missing,
>> then the "From:" line from the email header will be used to determine
>> the patch author in the changelog.
>> "
>>
>> You should take a look at how Andrew Morton works
>> when he fixes minor things, I am sure he fixes much
>> more than you do.
>
> +1
>

Dave, please help me understand the rules here.
Jamal gave me untested patch that had 8 lines deleted and said
"untested... to push it please go ahead."
I've removed one more line and added 2 extra.
My understanding is that 'From' applies to 100% authorship, no?
If no, where is the line?
I've seen people adding 'joint work' line and add sobs in order
of contribution % where the guy who sends it to the list is the
last sob, right?
Or any follow up work that based even on 10% of initial patch should
have 'from' of the first author? That doesn't sound right.
