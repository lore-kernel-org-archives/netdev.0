From: Andy Furniss <andyqos@ukfsn.org>
Subject: Re: [Announce] LARTC wiki available
Date: Sat, 02 Jun 2012 17:58:54 +0100
Message-ID: <4FCA464E.5030002@ukfsn.org>
References: <4EFB3B2B.7060200@linuxsystems.it>  <4FC8F0E4.6060102@linuxsystems.it>  <8063b8e35d17fd072cbdc9908cf12519@njm.linuxwall.info>  <4FCA2545.60702@ukfsn.org> <1338652231.2760.1706.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julien Vehent <julien@linuxwall.info>,
	=?UTF-8?B?TmljY29sw7IgQmVsbGk=?= <darkbasic@linuxsystems.it>,
	lartc@vger.kernel.org, netfilter@vger.kernel.org,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1338652231.2760.1706.camel@edumazet-glaptop>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> On Sat, 2012-06-02 at 15:37 +0100, Andy Furniss wrote:
>
>>
>> Anyway it seems that early this year SFQ got some love and now has
>> several more options (red, headdrop, limit>127, depth as param) - so as
>> long as your iproute/kernel is current have a look at man tc-sfq for
>> details.
>
> Yes, but fq_codel is really better than SFQ.

Ooh, that does look interesting. I hadn't seen that, thanks.
I should really start checking netdev again.

Just pulled iproute git, and see there is a man for codel, but not 
fq_codel (yet?).
It would be handy if it/them were added to man tc's "SEE ALSO" section.
