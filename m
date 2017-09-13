From: Laura Abbott <labbott@redhat.com>
Subject: Re: 319554f284dd ("inet: don't use sk_v6_rcv_saddr directly") causes
 bind port regression
Date: Wed, 13 Sep 2017 08:44:48 -0700
Message-ID: <588f3795-931e-7779-4ec7-5fe7d4437927@redhat.com>
References: <1a8ef376-387e-e0fc-7362-e1fd2c2c45d3@redhat.com>
 <AF16C126-99CA-401A-B803-AA05CDFBFF93@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Cole Robinson <crobinso@redhat.com>
To: Josef Bacik <jbacik@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AF16C126-99CA-401A-B803-AA05CDFBFF93@fb.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/12/2017 04:12 PM, Josef Bacik wrote:
> First I’m super sorry for the top post, I’m at plumbers and I forgot to upload my muttrc to my new cloud instance, so I’m screwed using outlook.
> 
> I have a completely untested, uncompiled patch that I think will fix the problem, would you mind giving it a go?  Thanks,
> 
> Josef

Thanks for the quick turnaround. Unfortunately, the problem is still
reproducible according to the reporter.

Thanks,
Laura
