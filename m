From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: e1000 close (NAPI)
Date: Fri, 10 Oct 2003 11:45:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102229749@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Robert Olsson" <Robert.Olsson@data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Other drivers may have the same issue. This was spotted 
> while stress-testing tulip. Patch was sent here some days
> ago. It's only seen if trying to close device under extreme
> loads. See the syncing code in dev_close()

Got it, thanks.
