From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net/dec: Make __de_get_link_ksettings return void
Date: Sun, 4 Jun 2017 20:24:09 +0300
Message-ID: <9bda442b-ef4b-0888-1717-241671375bce@cogentembedded.com>
References: <20170604170851.3808-1-yuval.shaia@oracle.com>
 <4391c380-f7f6-d549-a225-716b9b9df664@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Yuval Shaia <yuval.shaia@oracle.com>, davem@davemloft.net,
        jarod@redhat.com, tklauser@distanz.ch, tremyfr@gmail.com,
        netdev@vger.kernel.org, linux-parisc@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <4391c380-f7f6-d549-a225-716b9b9df664@cogentembedded.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/4/2017 8:22 PM, Sergei Shtylyov wrote:

>> Make return value void since function never return meaningfull value
>
>   You only make 1 of 2 functions void. It looks like there should be 2 patches.

    Oh, sorry, I was just blind. B-)

MBR, Sergei

