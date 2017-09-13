From: Cole Robinson <crobinso@redhat.com>
Subject: Re: 319554f284dd ("inet: don't use sk_v6_rcv_saddr directly") causes
 bind port regression
Date: Wed, 13 Sep 2017 13:40:13 -0400
Message-ID: <370b38d5-346c-91df-4ad4-79886ae3a9ba@redhat.com>
References: <1a8ef376-387e-e0fc-7362-e1fd2c2c45d3@redhat.com>
 <AF16C126-99CA-401A-B803-AA05CDFBFF93@fb.com>
 <588f3795-931e-7779-4ec7-5fe7d4437927@redhat.com>
 <EF55EF02-AD40-4F06-8C07-4F9F4221BFE6@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Josef Bacik <jbacik@fb.com>, Laura Abbott <labbott@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <EF55EF02-AD40-4F06-8C07-4F9F4221BFE6@fb.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/13/2017 01:28 PM, Josef Bacik wrote:
> Sorry I thought I had made this other fix, can you apply this on top of the other one and try that?  I have more things to try if this doesn’t work, sorry you are playing go between, but I want to make sure I know _which_ fix actually fixes the problem, and then clean up in followup patches.  Thanks,
> 

I'm the bug reporter. I'll combine the two patches and report back

Thanks,
Cole
