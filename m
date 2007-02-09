From: "dragoran dragoran" <drago01@gmail.com>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel
	PRO/Wireless 3945ABG
Date: Fri, 9 Feb 2007 23:48:17 +0100
Message-ID: <f6ca9fed0702091448m593fdef2sa184c7bea211bc10@mail.gmail.com>
References: <45CCE3CA.4050904@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1989332190=="
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, ipw3945-devel@lists.sourceforge.net
To: "James Ketrenos" <jketreno@linux.intel.com>
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
In-Reply-To: <45CCE3CA.4050904@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============1989332190==
Content-Type: multipart/alternative;
	boundary="----=_Part_21111_8325953.1171061297902"

------=_Part_21111_8325953.1171061297902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 2/9/07, James Ketrenos <jketreno@linux.intel.com> wrote:
>
> Please hold all questions until I am done with this email.  Thank you.
>
> We are pleased to announce the availability of a new driver for the
> Intel PRO/Wireless 3945ABG Network Connection adapter.  This new driver
> uses the new d80211 subsystem previously only available as part of the
> wireless-dev tree.
>
> You can find the new driver, and additional information about it, here:
>
>    http://intellinuxwireless.org/iwlwifi.
>
> Within the new driver package are sources which we plan to submit for
> kernel inclusion as well as scripts and patches which create a version
> of the driver which can be loaded into kernels based on 2.6.18 and newer
> (provided you have installed the d80211 subsystem as well)  The README
> document can walk you through pretty quickly.
>
> Since a lot of our users are not able to move to the latest versions of
> the Linux kernel, we have put together a d80211 package allowing the
> installation of the d80211 subsystem into an existing kernel image
> without the need to migrate to wireless-dev, or upgrade to a newer
> kernel at all (assuming you are using 2.6.18 or newer).
>
> You can find that package at:
>
>    http://intellinuxwireless.org/d80211
>
> Ok.  Now... any questions?


yes
first great wor finally no more  daemon ;)
now my question:
does this driver still supports wext? or  is it not  useable by
networkmanager?

Thanks,
> James / Intel Corporation
>
> -------------------------------------------------------------------------
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job
> easier.
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> Ipw3945-devel mailing list
> Ipw3945-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/ipw3945-devel
>

------=_Part_21111_8325953.1171061297902
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<br><br><div><span class="gmail_quote">On 2/9/07, <b class="gmail_sendername">James Ketrenos</b> &lt;<a href="mailto:jketreno@linux.intel.com">jketreno@linux.intel.com</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
Please hold all questions until I am done with this email.&nbsp;&nbsp;Thank you.<br><br>We are pleased to announce the availability of a new driver for the<br>Intel PRO/Wireless 3945ABG Network Connection adapter.&nbsp;&nbsp;This new driver<br>
uses the new d80211 subsystem previously only available as part of the<br>wireless-dev tree.<br><br>You can find the new driver, and additional information about it, here:<br><br>&nbsp;&nbsp; <a href="http://intellinuxwireless.org/iwlwifi">
http://intellinuxwireless.org/iwlwifi</a>.<br><br>Within the new driver package are sources which we plan to submit for<br>kernel inclusion as well as scripts and patches which create a version<br>of the driver which can be loaded into kernels based on 
2.6.18 and newer<br>(provided you have installed the d80211 subsystem as well)&nbsp;&nbsp;The README<br>document can walk you through pretty quickly.<br><br>Since a lot of our users are not able to move to the latest versions of<br>
the Linux kernel, we have put together a d80211 package allowing the<br>installation of the d80211 subsystem into an existing kernel image<br>without the need to migrate to wireless-dev, or upgrade to a newer<br>kernel at all (assuming you are using 
2.6.18 or newer).<br><br>You can find that package at:<br><br>&nbsp;&nbsp; <a href="http://intellinuxwireless.org/d80211">http://intellinuxwireless.org/d80211</a><br><br>Ok.&nbsp;&nbsp;Now... any questions?</blockquote><div><br>yes<br>first great wor finally no more&nbsp; daemon ;)
<br>now my question:<br>does this driver still supports wext? or&nbsp; is it not&nbsp; useable by networkmanager? <br></div><br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
Thanks,<br>James / Intel Corporation<br><br>-------------------------------------------------------------------------<br>Using Tomcat but need to do more? Need to support web services, security?<br>Get stuff done quickly with pre-integrated technology to make your job easier.
<br>Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo<br><a href="http://sel.as-us.falkag.net/sel?cmd=lnk&amp;kid=120709&amp;bid=263057&amp;dat=121642">http://sel.as-us.falkag.net/sel?cmd=lnk&amp;kid=120709&amp;bid=263057&amp;dat=121642
</a><br>_______________________________________________<br>Ipw3945-devel mailing list<br><a href="mailto:Ipw3945-devel@lists.sourceforge.net">Ipw3945-devel@lists.sourceforge.net</a><br><a href="https://lists.sourceforge.net/lists/listinfo/ipw3945-devel">
https://lists.sourceforge.net/lists/listinfo/ipw3945-devel</a><br></blockquote></div><br>

------=_Part_21111_8325953.1171061297902--


--===============1989332190==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1989332190==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Ipw3945-devel mailing list
Ipw3945-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/ipw3945-devel

--===============1989332190==--
