From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH PKT_SCHED 0/17]: tc action cleanup + fixes
Date: Thu, 30 Dec 2004 20:12:04 -0200
Message-ID: <41D47D34.1000708@conectiva.com.br>
References: <41D3785F.3040909@trash.net> <1104382562.1048.39.camel@jzny.localdomain> <41D3F5EC.9050808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41D3F5EC.9050808@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> jamal wrote:
> 
>> Patrick,
>> Thanks for this cleanup.
>>
>> Questions/comments:
>>
>> 1)compiler or style issue?
>>
>> You have a few of fixes from
>>
>> a)
>>  if (..){
>>     single statement here;
>> }
>>  
>> to:
>> if (..)
>>     single statement here;
>>
>> I always add an extra pair of brace
>> for lazy reasons (in the back of my mind: incase i want to add another
>> statement ;->).
> 
> 
> Just cleanup, I prefer not to waste too many lines. Saving
> space increases readability.

Agreed, whenever I have the chance, I remove such bloat ;)

- Arnaldo
