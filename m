From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [patch 2/5 2.4] e1000 - Fix MODULE_PARM, module_param and
	module_param_array usage
Date: Fri, 17 Sep 2004 19:42:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095475337.3496.5.camel@localhost.localdomain>
References: <Pine.LNX.4.44.0409170218100.15233-100000@isotope.jf.intel.com>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0409170218100.15233-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

What's this patch really about?

The only real change I see is the default ITR going from 8000 back to 1
(= dynamic mode).  What's this got to do with MODULE_PARAM, etc?  BTW,
wasn't there a big change to go from 1 to 8000.  Now this undoes that?

The rest of the changes look like someone is messing up the
whitespacing.  Why?

-scott
