From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 patch kernel 2.4.25
Date: Wed, 10 Mar 2004 21:56:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040310215620.A31831@electric-eye.fr.zoreil.com>
References: <20040308231303.C936@electric-eye.fr.zoreil.com> <404CF41C.2060807@netsite.com.br> <20040308235558.D936@electric-eye.fr.zoreil.com> <404D0363.9030407@netsite.com.br> <20040309010841.F936@electric-eye.fr.zoreil.com> <404D12C3.4000702@netsite.com.br> <20040309090747.A9256@electric-eye.fr.zoreil.com> <404DDB88.2080000@netsite.com.br> <20040310011358.A16937@electric-eye.fr.zoreil.com> <1078927570.1812.6.camel@territory>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marco Sinhoreli <msinhore@netsite.com.br>
Content-Disposition: inline
In-Reply-To: <1078927570.1812.6.camel@territory>; from msinhore@netsite.com.br on Wed, Mar 10, 2004 at 11:06:10AM -0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Marco Sinhoreli <msinhore@netsite.com.br> :
[...]
> I will be waiting the code of backport to drive r8169 for I test with
> the rsync. 

Try that:
http://www.fr.zoreil.com/linux/kernel/2.4.x/2.4.26-pre2/r8169-mammoth-attack.patch

It should turn your 2.4.26-pre2 into a decently up-to-date/patched 2.6.x r8169
driver (it does not include the misbehaving addr-high code). Please keep
netdev Cced an provide a summary of your experiences.

For the curious, the parts of the patch are in the same directory (not really
different from the 2.6.x version actually).

--
Ueimor
