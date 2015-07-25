From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: minimize TX data copying
Date: Sat, 25 Jul 2015 23:49:27 +0300
Message-ID: <55B3F657.8090606@cogentembedded.com>
References: <7692456.7SI5hJLWyQ@wasted.cogentembedded.com>
 <20150725204037.GA2172@nanopsycho.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20150725204037.GA2172@nanopsycho.fritz.box>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 07/25/2015 11:40 PM, Jiri Pirko wrote:

> <snip>

>> The patch is against Dave Miller's 'net-next.git' repo.

    Dave, don't apply this yet, I'll post v2 with couple of comments fixed up.

> You can just put "net-next" into patch brackets like:
> [patch net-next] whatever
> That would do the trick :)

    Oh, I know. :-)
    I just prefer to do this kind of thing uniformly regardless of the target 
repo.

MBR, Sergei

