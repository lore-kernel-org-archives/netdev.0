From: Anoob Soman <anoob.soman@citrix.com>
Subject: Re: [PATCH 4.4-only] openvswitch: clear sender cpu before forwarding
 packets
Date: Fri, 19 May 2017 11:28:02 +0100
Message-ID: <73c93eff-c16f-ebce-9eb4-75c698ec2b1f@citrix.com>
References: <1494944710-7901-1-git-send-email-anoob.soman@citrix.com>
 <20170517081933.GA25610@kroah.com>
 <371bcd34-10fa-867f-8bfb-7f61caf11cbe@citrix.com>
 <20170518081149.GA31512@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <stable@vger.kernel.org>, <pshelar@nicira.com>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <dev@openvswitch.org>, <linux-kernel@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170518081149.GA31512@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/05/17 09:11, Greg KH wrote:
> So backporting that one patch solves the issue here?  Can you please
> verify it, and let me know before I apply it?
>
> thanks,
>
> greg k-h

yes, I can do that.
