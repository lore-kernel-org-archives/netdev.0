From: Zilvinas Valinskas <zilvinas@gemtek.lt>
Subject: Re: Crypto tests via tcrypt.o modules failes
Date: Fri, 17 Sep 2004 18:21:26 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095434486.32091.2.camel@swoop.gemtek.lt>
References: <Xine.LNX.4.44.0409171056470.7996-100000@thoron.boston.redhat.com>
Reply-To: zilvinas@gemtek.lt
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0409171056470.7996-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-09-17 at 17:58, James Morris wrote:
> On Thu, 16 Sep 2004, Zilvinas Valinskas wrote:
> 
> > I would say Xscale IXP425 has a rather interesting 32, 16 bits
> > read/write results if address is not aligned properly. In the same
> > directory - http://www.gemtek.lt/~zilvinas/crypto/ i've put *.pdf
> > describing what exactly is happening. 
> 
> I've had a report that all is well on an Xscale PXA (SoC) system, with a 
> 2.6.7-rc2 kernel.  Are there any significant differences between that and 
> what you have?
2.4.27 and 2.6.7-rc2 I think quite different - can you tell me which
parts to check for differencies ?

Here I use 2.4.27 + IPsec patch (from Herbert Xu) + Xscale bits
(arch/arm - directory is only patched). I can do a full diff between 
vanilla 2.4.27 and what I've got if you like and put on web.

> 
> - James
